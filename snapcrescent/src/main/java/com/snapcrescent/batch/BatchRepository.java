package com.snapcrescent.batch;

import java.util.List;

import com.snapcrescent.common.BaseRepository;
import com.snapcrescent.common.utils.Constant.BatchStatus;

import jakarta.persistence.TypedQuery;

public abstract class BatchRepository<B> extends BaseRepository<B> {
	
	private final Class<B> type;
	
	public BatchRepository(Class<B> type) {
		super(type);
		this.type = type;
	}

	public B findAnyPending() {
		String query = "SELECT entity FROM "+ type.getName() +  " entity WHERE entity.batchStatus = :batchStatus";
		
		TypedQuery<B> typedQuery = entityManager.createQuery(query,type);
		typedQuery.setMaxResults(1);
		
		typedQuery.setParameter("batchStatus", BatchStatus.PENDING.getId());
		List<B> results =  typedQuery.getResultList();
		
		B result = null;
		
		if(results.size() > 0) {
			result = results.get(0);
		} 
		
		return result;
	}

}
