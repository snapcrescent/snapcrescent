package com.snapcrescent.metadata;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

import jakarta.persistence.TypedQuery;

@Repository
public class MetadataRepository extends BaseRepository<Metadata> {

	public MetadataRepository() {
		super(Metadata.class);
	}

	public Metadata findByHash(long hash) {
		String query = "SELECT metadata FROM Metadata metadata WHERE metadata.hash = :hash";

		TypedQuery<Metadata> typedQuery = entityManager.createQuery(query, Metadata.class);
		typedQuery.setParameter("hash", hash);
		List<Metadata> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}

	public boolean existByName(String name) {
		String query = "SELECT metadata FROM Metadata metadata WHERE metadata.name = :name";

		TypedQuery<Metadata> typedQuery = entityManager.createQuery(query, Metadata.class);
		typedQuery.setParameter("name", name);
		List<Metadata> results = typedQuery.getResultList();
		return results.isEmpty() ? false : true;
	}
}
