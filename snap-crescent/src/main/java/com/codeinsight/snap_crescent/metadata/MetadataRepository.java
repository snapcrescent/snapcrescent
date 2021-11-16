package com.codeinsight.snap_crescent.metadata;

import java.util.List;

import javax.persistence.TypedQuery;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class MetadataRepository extends BaseRepository<Metadata>{
	
	public MetadataRepository() {
		super(Metadata.class);
	}

	public boolean existsByHash(long hash) {
		String query = "SELECT metadata FROM Metadata metadata WHERE metadata.hash = :hash";
		
		TypedQuery<Metadata> typedQuery = getCurrentSession().createQuery(query,Metadata.class);
		typedQuery.setParameter("hash", hash);
		List<Metadata> results = typedQuery.getResultList();
		return results.isEmpty() ? false : true;
	}
}
