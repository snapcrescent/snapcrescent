package com.snapcrescent.location;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;

@Component
public class LocationConverter extends BaseConverter<Location, UiLocation>{
	
	@Autowired
	private LocationRepository locationRepository;
	
	public LocationConverter() {
		super(Location.class, UiLocation.class);
	}
	
	@Override
	public Location loadEntityById(Long id) {
		return locationRepository.loadById(id);
	}

}
