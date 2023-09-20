package com.richminime.domain.item.service;

import com.richminime.domain.item.dto.ItemResDto;
import com.richminime.domain.item.dto.ItemSearchCondition;

import java.util.List;
import java.util.Optional;

public interface UserItemService {

    // 1. 소유한 테마 전체 조회
    List<ItemResDto> findAllUserItem(String token);
//    List<ItemResDto> findAllUserItem(Long userId);

    // 3. 소유한 테마 상세 조회
    ItemResDto findUserItem(Long itemId, String token);

    // 5-1. 소유한 테마 적용하기
    // 5-2. 소유한 테마 벗기기
    Optional<ItemResDto> updateUserItem(Long itemId, String token);

    // 소유하지 않은 테마 구매하기
    ItemResDto addUserItem(Long itemId, String token);

    // 6. 소유한 테마 판매하기
    void deleteUserItem(Long userItemId, String token);

    // 2. 소유한 테마 카테고리별 조회(확장)
    List<ItemResDto> findAllUserItemByCondition(ItemSearchCondition condition, String token);

}
