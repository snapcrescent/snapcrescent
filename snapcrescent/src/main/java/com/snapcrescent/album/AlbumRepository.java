package com.snapcrescent.album;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;
import com.snapcrescent.common.utils.Constant.AlbumType;
import com.snapcrescent.common.utils.SearchDAOHelper;
import com.snapcrescent.common.utils.StringUtils;

import jakarta.persistence.TypedQuery;

@Repository
public class AlbumRepository extends BaseRepository<Album> {

	public AlbumRepository() {
		super(Album.class);
	}

	public int count(AlbumSearchCriteria searchCriteria) {
		int totalRows = 0;
		TypedQuery<Long> query = getSearchQuery(searchCriteria, true,  Long.class);
		totalRows = query.getResultList().get(0).intValue();

		return totalRows;
	}

	public List<Album> search(AlbumSearchCriteria searchCriteria, boolean isExportRequest) {
		TypedQuery<Album> query = getSearchQuery(searchCriteria, false, Album.class);
		if (!isExportRequest) {
			addPagingParameters(query, searchCriteria);
		}
		return query.getResultList();
	}
	
	public <T> TypedQuery<T> getSearchQuery(AlbumSearchCriteria searchCriteria, boolean isCountQuery,  Class<T> type) {
		// standard fields
		Boolean isSearchKeyword = Boolean.FALSE;
		Map<String, Object> paramsMap = new HashMap<>();

		SearchDAOHelper<T> daoHelper = new SearchDAOHelper<T>();

		StringBuffer hql = null;
		if (isCountQuery) {
			hql = new StringBuffer("SELECT count(distinct album.id)");
		}
		else {
			hql = new StringBuffer("SELECT distinct album");
		}

		hql.append(" FROM Album album");
		
		if(searchCriteria.getUserId() != null)
		{
			hql.append(" JOIN " + getJoinFetchType(isCountQuery) + " album.users user");
		}
		
		hql.append(" where 1=1 ");

		if (searchCriteria != null && StringUtils.isNotBlank(searchCriteria.getSearchKeyword())) {
			isSearchKeyword = Boolean.TRUE;
			String[] stringFields = {"metadata.model"};
			String[] numberFields = {};
			hql.append(daoHelper.getSearchWhereStatement(stringFields, numberFields, searchCriteria.getSearchKeyword(),
					true));
		}
		
		if(searchCriteria.getUserId() != null)
		{
			hql.append(" AND user.id = :userId ");
			paramsMap.put("userId", searchCriteria.getUserId());
		}
		
		if(searchCriteria.getCreatedByUserId() != null)
		{
			hql.append(" AND album.createdByUserId = :createdByUserId ");
			paramsMap.put("createdByUserId", searchCriteria.getCreatedByUserId());
		}
		
		
		if(searchCriteria.getActive() != null)
		{
			hql.append(" AND album.active = :active ");
			paramsMap.put("active", searchCriteria.getActive());
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
	
	public Album findDefaultAlbumByUserId(Long createdByUserId) {
		String query = "SELECT album FROM Album album WHERE album.createdByUserId = :createdByUserId AND album.albumType = :albumType";
		
		TypedQuery<Album> typedQuery = entityManager.createQuery(query,Album.class);
		typedQuery.setParameter("createdByUserId", createdByUserId);
		typedQuery.setParameter("albumType", AlbumType.DEFAULT.getId());
		List<Album> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}
}
