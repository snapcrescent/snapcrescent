package com.codeinsight.snap_crescent.photo;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface PhotoRepository extends JpaRepository<Photo, Long>, QuerydslPredicateExecutor<Photo>{

	@Query("SELECT photo from Photo photo"
			+ " LEFT JOIN photo.metadata metadata"
			+ " LEFT JOIN metadata.location location"
			+ " WHERE"
			+ " (:favorite is null OR photo.favorite = :favorite)"
			+ " AND"
			+ " (:month is null OR metadata.createdDate like concat('%','-',:month,'-','%'))"
			+ " AND"
			+ " (:year is null OR metadata.createdDate like concat('%',:year,'-','%'))"
			+ " AND"
			+ " (:searchInput is null OR lower(metadata.model) like concat('%',lower(trim(:searchInput)),'%')"
			+ " OR"
			+ " lower(location.city) like concat('%',lower(trim(:searchInput)),'%')"
			+ " OR"
			+ " lower(location.state) like concat('%',lower(trim(:searchInput)),'%')"
			+ " OR"
			+ " lower(location.country) like concat('%',lower(trim(:searchInput)),'%')"
			+ " OR"
			+ " lower(location.town) like concat('%',lower(trim(:searchInput)),'%'))")
	Page<Photo> search(Boolean favorite, String searchInput, String month, String year, Pageable pageable);
}
