package com.snapcrescent.asset;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;
import com.snapcrescent.common.utils.SearchDAOHelper;
import com.snapcrescent.common.utils.StringUtils;

import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

@Repository
public class AssetRepository extends BaseRepository<Asset>{
	
	public AssetRepository() {
		super(Asset.class);
	}
	
	public int count(AssetSearchCriteria searchCriteria) {
		int totalRows = 0;
		TypedQuery<Long> query = getSearchQuery(searchCriteria, true,  Long.class);
		totalRows = query.getResultList().get(0).intValue();

		return totalRows;
	}

	public List<Asset> search(AssetSearchCriteria searchCriteria, boolean isExportRequest) {
		TypedQuery<Asset> query = getSearchQuery(searchCriteria, false, Asset.class);
		if (!isExportRequest) {
			addPagingParameters(query, searchCriteria);
		}
		return query.getResultList();
	}
	
	public <T> TypedQuery<T> getSearchQuery(AssetSearchCriteria searchCriteria, boolean isCountQuery,  Class<T> type) {
		// standard fields
		Boolean isSearchKeyword = Boolean.FALSE;
		Map<String, Object> paramsMap = new HashMap<>();

		SearchDAOHelper<T> daoHelper = new SearchDAOHelper<T>();

		StringBuffer hql = null;
		if (isCountQuery) {
			hql = new StringBuffer("SELECT count(distinct asset.id)");
		}
		else {
			hql = new StringBuffer("SELECT distinct asset");
		}

		hql.append(" FROM Asset asset");
		
		
		
		hql.append(" LEFT JOIN " + getJoinFetchType(isCountQuery) + " asset.metadata metadata");
		hql.append(" LEFT JOIN " + getJoinFetchType(isCountQuery) + " asset.thumbnail thumbnail");
		
		hql.append(" where 1=1 ");

		if (searchCriteria != null && StringUtils.isNotBlank(searchCriteria.getSearchKeyword())) {
			isSearchKeyword = Boolean.TRUE;
			String[] stringFields = {"metadata.model"};
			String[] numberFields = {};
			hql.append(daoHelper.getSearchWhereStatement(stringFields, numberFields, searchCriteria.getSearchKeyword(),
					true));
		}
		
		hql.append(" AND asset.createdByUserId = :ownerId ");
		paramsMap.put("ownerId", searchCriteria.getOwnerId());
		
		if(searchCriteria.getFromDate() != null)
		{
			hql.append(" AND metadata.creationDateTime >= :fromDate");
			paramsMap.put("fromDate", searchCriteria.getFromDate());
		}

		if(searchCriteria.getToDate() != null)
		{
			hql.append(" AND metadata.creationDateTime <= :toDate");
			paramsMap.put("toDate", searchCriteria.getToDate());
		}
		
		if(searchCriteria.getActive() != null)
		{
			hql.append(" AND asset.active = :active ");
			paramsMap.put("active", searchCriteria.getActive());
		}
		
		if(searchCriteria.getAssetType() != null)
		{
			hql.append(" AND asset.assetType = :assetType ");
			paramsMap.put("assetType", searchCriteria.getAssetType());
		}
		
		if(searchCriteria.getFavorite() != null)
		{
			hql.append(" AND asset.favorite = :favorite ");
			paramsMap.put("favorite", searchCriteria.getFavorite());
		}
		
		if(isCountQuery == false && searchCriteria.getSortBy() != null){
			hql.append(" ORDER BY " + searchCriteria.getSortBy() + " " + searchCriteria.getSortOrder());
		}

		TypedQuery<T> q = entityManager.createQuery(hql.toString(), type);

		if (isSearchKeyword) {
			daoHelper.setSearchStringValue(q);
		}

		for (Entry<String, Object> parameterEntry : paramsMap.entrySet()) {
			q.setParameter(parameterEntry.getKey(), parameterEntry.getValue());
		}

		return q;
	}
	
	public void updateActiveFlag(Boolean active, List<Long> ids) {
		String queryString = "UPDATE Asset asset set asset.active = :active WHERE asset.id IN (:ids)";
		
		Query query = entityManager.createQuery(queryString);
		query.setParameter("ids", ids);
		query.setParameter("active", active);
		query.executeUpdate();
	}
	
	public void updateFavoriteFlag(Boolean favorite, List<Long> ids) {
		String queryString = "UPDATE Asset asset set asset.favorite = :favorite WHERE asset.id IN (:ids)";
		
		Query query = entityManager.createQuery(queryString);
		query.setParameter("ids", ids);
		query.setParameter("favorite", favorite);
		query.executeUpdate();
	}
	
	

	
	public Asset findByMetadataId(Long metadataId) {
		String query = "SELECT asset FROM Asset asset WHERE asset.metadataId = :metadataId";
		
		TypedQuery<Asset> typedQuery = entityManager.createQuery(query,Asset.class);
		typedQuery.setParameter("metadataId", metadataId);
		List<Asset> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}
	
	public List<UiAssetTimeline> getAssetTimeline(AssetSearchCriteria searchCriteria) {
		
		Map<String, Object> paramsMap = new HashMap<>();
		
		StringBuffer hql = new StringBuffer("SELECT new com.snapcrescent.asset.UiAssetTimeline(count(metadata),metadata.creationDateTime)");
	
		
		hql.append(" FROM Asset asset");
		hql.append(" LEFT JOIN asset.metadata metadata");
		
		hql.append(" where 1=1 ");
		
		hql.append(" AND asset.createdByUserId = :ownerId ");
		paramsMap.put("ownerId", searchCriteria.getOwnerId());
		
		if(searchCriteria.getActive() != null)
		{
			hql.append(" AND asset.active = :active ");
			paramsMap.put("active", searchCriteria.getActive());
		}
		
		if(searchCriteria.getFavorite() != null)
		{
			hql.append(" AND asset.favorite = :favorite ");
			paramsMap.put("favorite", searchCriteria.getFavorite());
		}
		
		hql.append(" GROUP BY YEAR(metadata.creationDateTime), MONTH(metadata.creationDateTime), DATE(metadata.creationDateTime) ");
		hql.append(" ORDER BY metadata.creationDateTime DESC ");
		
		
		TypedQuery<UiAssetTimeline> typedQuery = entityManager.createQuery(hql.toString(),UiAssetTimeline.class);
		
		for (Entry<String, Object> parameterEntry : paramsMap.entrySet()) {
			typedQuery.setParameter(parameterEntry.getKey(), parameterEntry.getValue());
		}
		
		List<UiAssetTimeline> results = typedQuery.getResultList();
		return results;
	}
	
}
