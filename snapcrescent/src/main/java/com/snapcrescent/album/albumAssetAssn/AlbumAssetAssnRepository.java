package com.snapcrescent.album.albumAssetAssn;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

import jakarta.persistence.Query;

@Repository
public class AlbumAssetAssnRepository extends BaseRepository<AlbumAssetAssn> {

	public AlbumAssetAssnRepository() {
		super(AlbumAssetAssn.class);
	}
	
	public void deleteByAssetId(Long assetId) {
		String queryString = "DELETE FROM AlbumAssetAssn albumAssetAssn JOIN albumAssetAssn.id.asset asset WHERE asset.id = :assetId";
		
		Query query = entityManager.createQuery(queryString);
		query.setParameter("assetId", assetId);
		query.executeUpdate();
	}
}
