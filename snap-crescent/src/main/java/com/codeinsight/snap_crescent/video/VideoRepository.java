package com.codeinsight.snap_crescent.video;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.persistence.TypedQuery;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;
import com.codeinsight.snap_crescent.common.utils.SearchDAOHelper;
import com.codeinsight.snap_crescent.common.utils.StringUtils;

@Repository
public class VideoRepository extends BaseRepository<Video>{
	
	public VideoRepository() {
		super(Video.class);
	}
	
	public int count(VideoSearchCriteria searchCriteria) {
		int totalRows = 0;
		TypedQuery<Long> query = getSearchQuery(searchCriteria, true,  Long.class);
		totalRows = query.getResultList().get(0).intValue();

		return totalRows;
	}

	public List<Video> search(VideoSearchCriteria searchCriteria, boolean isExportRequest) {
		TypedQuery<Video> query = getSearchQuery(searchCriteria, false, Video.class);
		if (!isExportRequest) {
			addPagingParameters(query, searchCriteria);
		}
		return query.getResultList();
	}
	
	public <T> TypedQuery<T> getSearchQuery(VideoSearchCriteria searchCriteria, boolean isCountQuery,  Class<T> type) {
		// standard fields
		Boolean isSearchKeyword = Boolean.FALSE;
		Map<String, Object> paramsMap = new HashMap<>();

		SearchDAOHelper<T> daoHelper = new SearchDAOHelper<T>();

		StringBuffer hql = null;
		if (isCountQuery) {
			hql = new StringBuffer("SELECT count(distinct video.id)");
		}
		else {
			hql = new StringBuffer("SELECT distinct video");
		}

		hql.append(" FROM Video video");
		
		hql.append(" LEFT JOIN video.videoMetadata videoMetadata");
		hql.append(" LEFT JOIN videoMetadata.location location");
		
		hql.append(" where 1=1 ");

		if (searchCriteria != null && StringUtils.isNotBlank(searchCriteria.getSearchKeyword())) {
			isSearchKeyword = Boolean.TRUE;
			String[] stringFields = {"metadata.model","location.city","location.state","location.country","location.town"};
			String[] numberFields = {};
			hql.append(daoHelper.getSearchWhereStatement(stringFields, numberFields, searchCriteria.getSearchKeyword(),
					true));
		}
		
		if(searchCriteria.getActive() != null)
		{
			hql.append(" AND video.active = :active ");
			paramsMap.put("active", searchCriteria.getActive());
		}
		
		if(searchCriteria.getFavorite() != null)
		{
			hql.append(" AND video.favorite = :favorite ");
			paramsMap.put("favorite", searchCriteria.getFavorite());
		}
		
		if(isCountQuery == false && searchCriteria.getSortBy() != null){
			hql.append(" ORDER BY " + searchCriteria.getSortBy() + " " + searchCriteria.getSortOrder());
		}

		TypedQuery<T> q = this.getCurrentSession().createQuery(hql.toString(), type);

		if (isSearchKeyword) {
			daoHelper.setSearchStringValue(q);
		}

		for (Entry<String, Object> parameterEntry : paramsMap.entrySet()) {
			q.setParameter(parameterEntry.getKey(), parameterEntry.getValue());
		}

		return q;
	}
	
}
