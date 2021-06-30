package com.codeinsight.snap_crescent.common;

import java.util.List;

import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;

import org.hibernate.HibernateException;
import org.hibernate.LockMode;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate5.HibernateTemplate;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;

public abstract class BaseRepository<T> {
	
	private final Class<T> type;

	public BaseRepository(Class<T> type) {
		this.type = type;
	}

	@Autowired
	protected HibernateTemplate hibernateTemplate;

	public Session getCurrentSession() {
		return hibernateTemplate.getSessionFactory().getCurrentSession();
	}

	public HibernateTemplate getHibernateTemplate() {
		return hibernateTemplate;
	}
	
	public List<T> findAll() {
		return hibernateTemplate.loadAll(type);
	}

	public void save(T entity) {
		hibernateTemplate.saveOrUpdate(entity);
	}

	/**
	 * Merge should be used with Auditable entities.
	 * 
	 * @param entity
	 */
	public void merge(Object entity) {
		hibernateTemplate.merge(entity);
	}

	public void update(Object entity) {
		hibernateTemplate.update(entity);
	}

	public void refresh(Object entity) {
		hibernateTemplate.refresh(entity);
	}

	public void detach(Object entity) {
		hibernateTemplate.evict(entity);
	}
	
	public T findById(Long id) {
		return hibernateTemplate.get(type, id);
	}

	public List<T> findByIds(List<Long> ids) {
		CriteriaBuilder criteriaBuilder = getCurrentSession().getCriteriaBuilder();
		CriteriaQuery<T> criteriaQuery = criteriaBuilder.createQuery(type);
		Root<T> root = criteriaQuery.from(type);

		criteriaQuery.select(root).where(root.get("id").in(ids));

		TypedQuery<T> query = getCurrentSession().createQuery(criteriaQuery);
		return query.getResultList();
	}

	public T loadById(Long id) {
		return hibernateTemplate.load(type, id);
	}

	public T findByIdLocked(Long id) {
		return hibernateTemplate.get(type, id, LockMode.UPGRADE_NOWAIT);
	}

	public void delete(T entityToDelete) {
		hibernateTemplate.delete(entityToDelete);
	}

	public void delete(Long id) {
		T entityToDelete = hibernateTemplate.load(type, id);
		if (entityToDelete == null)
			throw new IllegalArgumentException("No " + type.getName() + " with id " + id);
		hibernateTemplate.delete(entityToDelete);
	}

	public void deleteByEntity(T entityToDelete) {
		hibernateTemplate.delete(entityToDelete);
	}

	public void delete(List<Long> ids) {
		if (ids != null) {
			for (Long id : ids) {
				T entityToDelete = hibernateTemplate.load(type, id);
				hibernateTemplate.delete(entityToDelete);
			}
		}

	}

	/**
	 * Force the current session to flush.
	 * 
	 * @throws HibernateException
	 * @see {@link org.hibernate.Session#flush()}
	 */
	public void flush() throws HibernateException {
		hibernateTemplate.flush();
	}

	protected String getJoinFetchType(Boolean isCountQuery, BaseSearchCriteria criteria, String joinTable) {

		String joinFetchType = " ";
		if (isCountQuery == false) {

			if (criteria.getSortBy() != null && criteria.getSortBy().contains(joinTable)) {
				joinFetchType = " fetch ";
			}
		}

		return joinFetchType;
	}

	protected String getJoinFetchType(Boolean isCountQuery, BaseSearchCriteria criteria, String[] joinTables) {

		String joinFetchType = " ";
		if (isCountQuery == false) {
			for (String joinTable : joinTables) {
				if (criteria.getSortBy() != null && criteria.getSortBy().contains(joinTable)) {
					joinFetchType = " fetch ";
				}
			}
		}

		return joinFetchType;
	}
	
	protected void addPagingParameters(TypedQuery<T> query,BaseSearchCriteria searchCriteria)
	{
		query.setFirstResult( (searchCriteria.getPageNumber() *  searchCriteria.getResultPerPage() ));
		query.setMaxResults(searchCriteria.getResultPerPage());
	}

}
