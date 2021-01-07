package com.codeinsight.snap_crescent.location;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface LocationRepository extends JpaRepository<Location, Long>, QuerydslPredicateExecutor<Location>{

}
