package com.codeinsight.snap_crescent.album;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface AlbumRepository extends JpaRepository<Album, Long>, QuerydslPredicateExecutor<Album> {

	@Query("SELECT album from Album album")
	Page<Album> search(Pageable pageable);
}
