package com.codeinsight.snap_crescent.userManagement;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

@RepositoryRestResource(path = "user", itemResourceRel = "user", collectionResourceRel = "users")
public interface UserRepository extends JpaRepository<User, Long>, QuerydslPredicateExecutor<User> {

	@RestResource(exported = false)
	public boolean existsByEmail(@Param("email") String email);
}
