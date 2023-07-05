package com.snapcrescent.album;

import java.util.List;

import lombok.Data;

@Data
public class UiCreateAlbumAssetAssnRequest {
	
	private List<UiAlbum> albums;
	private List<Long> assetIds;
}
