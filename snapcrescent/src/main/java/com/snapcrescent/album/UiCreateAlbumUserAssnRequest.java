package com.snapcrescent.album;

import java.util.List;

import lombok.Data;

@Data
public class UiCreateAlbumUserAssnRequest {
	
	private Long albumId;
	private List<Long> userIds;
}
