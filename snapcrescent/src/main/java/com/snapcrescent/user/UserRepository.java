package com.snapcrescent.user;

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
public class UserRepository extends BaseRepository<User> {

	public UserRepository() {
		super(User.class);
	}

	public User findByUsername(String username) {
		String query = "SELECT user FROM User user WHERE user.username = :username";
		
		TypedQuery<User> typedQuery = entityManager.createQuery(query,User.class);
		typedQuery.setParameter("username", username);
		List<User> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}
	
	
	public int count(UserSearchCriteria searchCriteria) {
		int totalRows = 0;
		TypedQuery<Long> query = getSearchQuery(searchCriteria, true,  Long.class);
		totalRows = query.getResultList().get(0).intValue();

		return totalRows;
	}

	public List<User> search(UserSearchCriteria searchCriteria, boolean isExportRequest) {
		TypedQuery<User> query = getSearchQuery(searchCriteria, false, User.class);
		if (!isExportRequest) {
			addPagingParameters(query, searchCriteria);
		}
		return query.getResultList();
	}
	
	public <T> TypedQuery<T> getSearchQuery(UserSearchCriteria searchCriteria, boolean isCountQuery,  Class<T> type) {
		// standard fields
		Boolean isSearchKeyword = Boolean.FALSE;
		Map<String, Object> paramsMap = new HashMap<>();

		SearchDAOHelper<T> daoHelper = new SearchDAOHelper<T>();

		StringBuffer hql = null;
		if (isCountQuery) {
			hql = new StringBuffer("SELECT count(distinct user.id)");
		}
		else {
			hql = new StringBuffer("SELECT distinct user");
		}

		hql.append(" FROM User user");
		
		
		hql.append(" where 1=1 ");

		if (searchCriteria != null && StringUtils.isNotBlank(searchCriteria.getSearchKeyword())) {
			isSearchKeyword = Boolean.TRUE;
			String[] stringFields = {"metadata.model"};
			String[] numberFields = {};
			hql.append(daoHelper.getSearchWhereStatement(stringFields, numberFields, searchCriteria.getSearchKeyword(),
					true));
		}
		
				
		if(searchCriteria.getActive() != null)
		{
			hql.append(" AND user.active = :active ");
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
	
	public void updatePasswordByUserId(String password, Long id) {
		String queryString = "UPDATE User user set user.password = :password WHERE user.id = :id";
		
		Query query = entityManager.createQuery(queryString);
		query.setParameter("password", password);
		query.setParameter("id", id);
		query.executeUpdate();
	}

	

}
