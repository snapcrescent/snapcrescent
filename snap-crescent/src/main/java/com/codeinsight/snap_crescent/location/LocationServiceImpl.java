package com.codeinsight.snap_crescent.location;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.codeinsight.snap_crescent.beans.GeolocationApiResponse;
import com.codeinsight.snap_crescent.utils.RestApiUtil;

@Service
public class LocationServiceImpl implements LocationService {

	@Autowired
	private RestApiUtil restApiUtil;

	@Autowired
	private LocationRepository locationRepository;

	@Override
	@Transactional
	public Long saveLocation(Double longitude, Double latitude) throws Exception {
		
		try {
			System.out.println("Get Location - Start");
			Location location = executeReverseGeoCoding(longitude, latitude);
			System.out.println("Get Location - End");
			location.setLongitude(longitude);
			location.setLatitude(latitude);
			System.out.println("Save Location - Start");
			locationRepository.save(location);
			System.out.println("Save Location - End");
			return location.getId();	
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;

	}

	private Location executeReverseGeoCoding(Double longitude, Double latitude) throws Exception {

		String url = "https://nominatim.openstreetmap.org/reverse?format=json&lon=" + longitude + "&lat=" + latitude;

		ResponseEntity<GeolocationApiResponse> responseEntity = restApiUtil.callApi(url, GeolocationApiResponse.class);
		GeolocationApiResponse response = responseEntity.getBody();

		return response.getAddress();
	}

}
