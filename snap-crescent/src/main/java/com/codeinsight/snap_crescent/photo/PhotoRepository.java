package com.codeinsight.snap_crescent.photo;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface PhotoRepository extends JpaRepository<Photo, Long>, QuerydslPredicateExecutor<Photo>{

	@Query("SELECT photo from Photo photo")
	Page<Photo> search(Pageable pageable);
}
