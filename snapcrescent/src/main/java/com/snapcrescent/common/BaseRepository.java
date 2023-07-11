package com.snapcrescent.common;

import java.util.List;

import org.hibernate.HibernateException;

import com.snapcrescent.common.beans.BaseSearchCriteria;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;

public abstract class BaseRepository<T> {
	
	private final Class<T> type;

	public BaseRepository(Class<T> type) {
		this.type = type;
	}

	@PersistenceContext
    protected EntityManager entityManager;
	
	public List<T> findAll() {
		
		String query = "SELECT entity FROM "+ type.getName() +  " entity";
	
		
		TypedQuery<T> typedQuery = entityManager.createQuery(query,type);
		return typedQuery.getResultList();
	}

	public void save(T entity) {
		entityManager.persist(entity);
	}

	/**
	 * Merge should be used with Auditable entities.
	 * 
	 * @param entity
	 */
	public void update(T entity) {
		entityManager.merge(entity);
	}

	public void refresh(T entity) {
		entityManager.refresh(entity);
	}

	public void detach(T entity) {
		entityManager.detach(entity);
	}
	
	public T findById(Long id) {
		return entityManager.find(type, id);
	}

	public List<T> findByIds(List<Long> ids) {
		CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
		CriteriaQuery<T> criteriaQuery = criteriaBuilder.createQuery(type);
		Root<T> root = criteriaQuery.from(type);

		criteriaQuery.select(root).where(root.get("id").in(ids));

		TypedQuery<T> query = entityManager.createQuery(criteriaQuery);
		return query.getResultList();
	}

	public T loadById(Long id) {
		return entityManager.getReference(type, id);
	}

	public void delete(T entityToDelete) {
		entityManager.remove(entityToDelete);
	}

	public void delete(Long id) {
		T entityToDelete = entityManager.getReference(type, id);
		if (entityToDelete == null)
			throw new IllegalArgumentException("No " + type.getName() + " with id " + id);
		entityManager.remove(entityToDelete);
	}

	public void deleteByEntity(T entityToDelete) {
		entityManager.remove(entityToDelete);
	}

	public void delete(List<Long> ids) {
		if (ids != null) {
			for (Long id : ids) {
				T entityToDelete = entityManager.getReference(type, id);
				entityManager.remove(entityToDelete);
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
		entityManager.flush();
	}
	
	protected String getJoinFetchType(Boolean isCountQuery) {

		String joinFetchType = " ";
		if (isCountQuery == false) {
			joinFetchType = " fetch ";
		}

		return joinFetchType;
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
