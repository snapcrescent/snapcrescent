package com.snapcrescent.album;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.user.User;

public interface AlbumService {

	public BaseResponseBean<Long, UiAlbum> search(AlbumSearchCriteria albumSearchCriteria);
	public UiAlbum save(UiAlbum album) throws Exception;
	public void update(UiAlbum album) throws Exception;
	void createOrUpdateDefaultAlbum(User entity) throws Exception;
	void createAlbumAssetAssociation(UiCreateAlbumAssetAssnRequest createAlbumAssetAssnRequest);
	public void updateOrDeleteAlbumPostUserDeletion(Long userId);
	public void updateAlbumPostAssetDeletion(Asset asset);
	public UiAlbum getById(Long id);
	UiAlbum getLiteById(Long id);
	public void delete(Long id);
	void persistAlbumAssetAssociationForDefaultAlbum(Long userId, Asset asset);
	

}
