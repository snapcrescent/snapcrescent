package com.codeinsight.snap_crescent.sync_info;

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
public class SyncInfoRepository extends BaseRepository<SyncInfo> {

	public SyncInfoRepository() {
		super(SyncInfo.class);
	}

	public int count(SyncInfoSearchCriteria searchCriteria) {
		int totalRows = 0;
		TypedQuery<Long> query = getSearchQuery(searchCriteria, true, Long.class);
		totalRows = query.getResultList().get(0).intValue();

		return totalRows;
	}

	public List<SyncInfo> search(SyncInfoSearchCriteria searchCriteria, boolean isExportRequest) {
		TypedQuery<SyncInfo> query = getSearchQuery(searchCriteria, false, SyncInfo.class);
		if (!isExportRequest) {
			addPagingParameters(query, searchCriteria);
		}
		return query.getResultList();
	}

	public <T> TypedQuery<T> getSearchQuery(SyncInfoSearchCriteria searchCriteria, boolean isCountQuery,
			Class<T> type) {
		// standard fields
		Boolean isSearchKeyword = Boolean.FALSE;
		Map<String, Object> paramsMap = new HashMap<>();

		SearchDAOHelper<T> daoHelper = new SearchDAOHelper<T>();

		StringBuffer hql = null;
		if (isCountQuery) {
			hql = new StringBuffer("SELECT count(distinct syncInfo.id)");
		} else {
			hql = new StringBuffer("SELECT distinct syncInfo");
		}

		hql.append(" FROM SyncInfo syncInfo");

		hql.append(" where 1=1 ");

		if (searchCriteria != null && StringUtils.isNotBlank(searchCriteria.getSearchKeyword())) {
			isSearchKeyword = Boolean.TRUE;
			String[] stringFields = {};
			String[] numberFields = {};
			hql.append(daoHelper.getSearchWhereStatement(stringFields, numberFields, searchCriteria.getSearchKeyword(),
					true));
		}

		if (searchCriteria.getActive() != null) {
			hql.append(" AND syncInfo.active = :active ");
			paramsMap.put("active", searchCriteria.getActive());
		}

		if (isCountQuery == false && searchCriteria.getSortBy() != null) {
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
