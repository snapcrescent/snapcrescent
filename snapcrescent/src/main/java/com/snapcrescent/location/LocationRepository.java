package com.snapcrescent.location;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class LocationRepository extends BaseRepository<Location> {

	public LocationRepository() {
		super(Location.class);
	}

}
