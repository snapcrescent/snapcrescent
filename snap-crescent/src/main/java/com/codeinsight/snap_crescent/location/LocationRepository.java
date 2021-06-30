package com.codeinsight.snap_crescent.location;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class LocationRepository extends BaseRepository<Location> {

	public LocationRepository() {
		super(Location.class);
	}

}
