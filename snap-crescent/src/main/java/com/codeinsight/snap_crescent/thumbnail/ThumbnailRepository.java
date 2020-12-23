package com.codeinsight.snap_crescent.thumbnail;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface ThumbnailRepository extends JpaRepository<Thumbnail, Long>, QuerydslPredicateExecutor<Thumbnail>{

}
