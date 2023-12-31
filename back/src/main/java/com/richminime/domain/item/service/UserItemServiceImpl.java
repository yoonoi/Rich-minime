package com.richminime.domain.item.service;

import com.richminime.domain.bankBook.constant.TransactionType;
import com.richminime.domain.bankBook.dao.BankBookRepository;
import com.richminime.domain.bankBook.domain.BankBook;
import com.richminime.domain.item.domain.Item;
import com.richminime.domain.item.constant.ItemType;
import com.richminime.domain.item.domain.UserItem;
import com.richminime.domain.item.dto.AddUserItemResDto;
import com.richminime.domain.item.dto.DeleteUserItemResDto;
import com.richminime.domain.item.dto.UserItemResDto;
import com.richminime.domain.item.exception.ItemDuplicatedException;
import com.richminime.domain.item.exception.ItemInsufficientBalanceException;
import com.richminime.domain.item.exception.ItemNotFoundException;
import com.richminime.domain.item.exception.ItemUserNotFoundException;
import com.richminime.domain.item.repository.ItemRepository;
import com.richminime.domain.item.repository.UserItemRepository;
import com.richminime.domain.user.domain.User;
import com.richminime.domain.user.exception.UserNotFoundException;
import com.richminime.domain.user.repository.UserRepository;
import com.richminime.global.exception.ForbiddenException;
import com.richminime.global.util.SecurityUtils;
import com.richminime.global.util.jwt.JWTUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import static com.richminime.domain.item.constant.ItemExceptionMessage.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserItemServiceImpl implements UserItemService {

    private final UserItemRepository userItemRepository;
    private final ItemRepository itemRepository;
    private final UserRepository userRepository;
    private final BankBookRepository bankBookRepository;
    private final SecurityUtils securityUtils;
//    private final JWTUtil jwtUtil;

    /**
     * 로그인 유저를 반환하는 메서드
     * @return loginUser
     */
    private User getLoginUser() {
        String email = securityUtils.getLoggedInUserEmail();

        User loginUser = userRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.error("[유저아이템 서비스] 로그인 유저를 찾을 수 없습니다.");
                    return new UserNotFoundException(ITEM_USER_NOT_FOUND.getMessage());
                });

        return loginUser;
    }

    /**
     * 소유한 테마 전체 조회
     * @return
     */
    @Transactional
    @Override
    public List<UserItemResDto> findAllUserItem() {
        String email = securityUtils.getLoggedInUserEmail();
        log.info("[소유한 테마 전체 조회] 사용자가 소유한 테마 전체 조회, userEmail : {}", email);

        User loginUser = getLoginUser();

        return userItemRepository.findAllByUser_UserId(loginUser.getUserId()).stream()
                .map(userItem -> UserItemResDto.entityToDto(userItem))
                .collect(Collectors.toList());
    }

    /**
     * 소유한 테마 카테고리별 조회
     * @param itemType
     * @return
     */
    @Transactional
    @Override
    public List<UserItemResDto> findAllUserItemByType(ItemType itemType) {
        if(itemType == null)
            return findAllUserItem();

        String email = securityUtils.getLoggedInUserEmail();
        log.info("[소유한 테마 카테고리별 조회] 사용자가 소유한 테마 조건별 조회. email : {}, 카테고리 : {}", email, itemType);

        User loginUser = getLoginUser();

        return userItemRepository.findAllByUser_UserIdAndItem_ItemType(loginUser.getUserId(), itemType).stream()
                .map(userItem -> UserItemResDto.entityToDto(userItem))
                .collect(Collectors.toList());
    }

    /**
     * 소유한 테마 상세 조회
     * @param userItemId
     * @return
     */
    @Transactional
    @Override
    public UserItemResDto findUserItem(Long userItemId) {
        String email = securityUtils.getLoggedInUserEmail();
        log.info("[소유한 테마 상세 조회] 사용자가 선택한 소유테마 상세 조회 요청. email : {}, userItemId : {}", email, userItemId);

        UserItem userItem = userItemRepository.findById(userItemId)
                .orElseThrow(() -> {
                    log.error("[소유한 테마 상세 조회] 테마를 찾을 수 없습니다.");
                    return new ItemNotFoundException(ITEM_NOT_FOUND.getMessage());
                });

        // UserItem의 User와 loginUser가 동일한지 체크
        if(!userItem.getUser().getEmail().equals(email)) {
            log.error("[소유한 테마 상세 조회] 로그인 유저가 소유한 테마만 상세조회 가능합니다.");
            throw new ItemUserNotFoundException(USERITEM_AUTHORIZATION_FAILED.getMessage());
        }

        log.info("[소유한 테마 상세 조회] 테마 상세 조회 완료.");
        return UserItemResDto.entityToDto(userItem);
    }

    /**
     * 소유하지 않은 테마 구매하기
     * @param itemId
     * @return
     */
    @Transactional
    @Override
    public AddUserItemResDto addUserItem(Long itemId) {
//        User loginUser = getLoginUser(token);
//        Long loginUserId = loginUser.getUserId();
        String email = securityUtils.getLoggedInUserEmail();

        log.info("[테마 구매하기] 테마 구매 요청. email : {}, itemId : {}", email, itemId);

        User loginUser = userRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.error("[테마 구매] 로그인 사용자 없음");
                    return new UserNotFoundException(ITEM_USER_NOT_FOUND.getMessage());
                });

        // 보유하고 있는 테마인지 확인
        Boolean alreadyOwned = userItemRepository.existsByUser_UserIdAndItem_ItemId(loginUser.getUserId(), itemId);

        // 보유중이면 구매 불가
        if(alreadyOwned) {
            log.error("[테마 구매하기] 기소유한 테마는 구매할 수 없습니다.");
            throw new ItemDuplicatedException(ITEM_DUPLICATED.getMessage());
        }

        // 소유 아이템 20개 이상이면 구매 불가
        if(loginUser.getItemCount() >= 20) {
            log.error("[테마 구매하기] 주머니가 가득차 구매할 수 없습니다.");
            throw new ItemDuplicatedException(ITEM_COUNT_OVER.getMessage());
        }

        Item item = itemRepository.findItemByItemId(itemId)
                .orElseThrow(() -> {
                    log.error("[테마 구매하기] 테마를 찾을 수 없습니다.");
                    return new ItemNotFoundException(ITEM_NOT_FOUND.getMessage());
                });

        // 잔액 확인
        long newBalance = loginUser.getBalance() - item.getPrice();

        // 잔액 부족이면 구매 불가
        if(newBalance < 0){
            log.error("[테마 구매하기] 잔액이 부족해 구매할 수 없습니다.");
            throw new ItemInsufficientBalanceException(ITEM_INSUFFICIENT_BALANCE.getMessage());
        }

        log.info("[테마 구매하기] 테마 구매 가능 !!");

        BankBook bankBook = BankBook.builder()
                .userId(loginUser.getUserId())
                .amount(item.getPrice())
                .date(LocalDate.now())
                .balance(newBalance)
                .transactionType(TransactionType.getTransactionType("구매"))
                .summary(item.getItemName() + " 구매")
                .build();

        bankBookRepository.save(bankBook);
        loginUser.updateBalance(newBalance);
        loginUser.updateItemCnt(true);

        UserItem userItem = UserItem.builder()
                .item(item)
                .user(loginUser)
                .build();

        userRepository.save(loginUser);
        userItemRepository.save(userItem);

        return AddUserItemResDto.entityToDto(userItem);
    }

    /**
     * 소유한 테마 판매하기
     * @param itemId
     */
    @Transactional
    @Override
    public DeleteUserItemResDto deleteUserItem(Long itemId) {
        log.info("[테마 판매하기] 소유한 테마 판매 요청. itemId : {}", itemId);

        User loginUser = getLoginUser();

        UserItem userItem = userItemRepository.findByUser_UserIdAndItem_ItemId(loginUser.getUserId(), itemId)
                .orElseThrow(() -> {
                    log.error("[테마 판매하기] 테마를 찾을 수 없습니다.");
                    return new ItemNotFoundException(USERITEM_NOT_FOUND.getMessage());
                });

        // 로그인 유저와 테마 소유자가 동일한지 체크
        if(!loginUser.getUserId().equals(userItem.getUser().getUserId())) {
            log.error("[테마 판매하기] 로그인 유저와 테마 소유자가 일치하지 않습니다. 판매 불가.");
            throw new ItemUserNotFoundException(USERITEM_AUTHORIZATION_FAILED.getMessage());
        }

        Long saleAmount = Math.round(userItem.getItem().getPrice() * 0.4);
        Long newBalance = loginUser.getBalance() + saleAmount;

        BankBook bankBook = BankBook.builder()
                .userId(loginUser.getUserId())
                .amount(saleAmount)
                .date(LocalDate.now())
                .balance(newBalance)
                .transactionType(TransactionType.getTransactionType("판매"))
                .summary(userItem.getItem().getItemName() + " 판매")
                .build();

        bankBookRepository.save(bankBook);

        loginUser.updateBalance(newBalance);
        loginUser.updateItemCnt(false);

        userItemRepository.delete(userItem);
        userRepository.save(loginUser);

        log.info("[테마 판매하기] 판매 완료.");

        return DeleteUserItemResDto.entityToDto(userItem);
    }

}
