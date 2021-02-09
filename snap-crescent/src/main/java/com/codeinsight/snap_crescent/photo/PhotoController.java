package com.codeinsight.snap_crescent.photo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.beans.BaseResponse;

@RestController
public class PhotoController {

	@Autowired
	private PhotoService photoService;

	@GetMapping("/photo")
	public ResponseEntity<?> search(@RequestParam Map<String, String> searchParams) {

		PhotoSearchCriteria searchCriteria = new PhotoSearchCriteria();

		parseSearchParams(searchParams, searchCriteria);
		String msg = "";
		try {
			return new ResponseEntity<>(photoService.search(searchCriteria), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			msg = e.getMessage();
		}
		return new ResponseEntity<>(msg, HttpStatus.INTERNAL_SERVER_ERROR);
	}

	private void parseSearchParams(Map<String, String> searchParams, PhotoSearchCriteria searchCriteria) {

		if (searchParams.get("page") != null) {
			searchCriteria.setPage(Integer.parseInt(searchParams.get("page")));
		}
		
		if (searchParams.get("size") != null) {
			searchCriteria.setSize(Integer.parseInt(searchParams.get("size")));
		}
		
		if (searchParams.get("favorite") != null) {
			searchCriteria.setFavorite(Boolean.parseBoolean(searchParams.get("favorite")));
		}
		
		if (searchParams.get("searchInput") != null) {
			searchCriteria.setSearchInput(searchParams.get("searchInput"));
		}
		
		if (searchParams.get("month") != null) {
			searchCriteria.setMonth(searchParams.get("month"));
		}
		
		if (searchParams.get("year") != null) {
			searchCriteria.setYear(searchParams.get("year"));
		}

		if (searchParams.get("sort") != null) {
			searchCriteria.setSort(searchParams.get("sort"));
		}
		
		if (searchParams.get("sortDirection") != null) {
			searchCriteria.setSortDirection(searchParams.get("sortDirection"));
		}
	}
	
	@GetMapping(value="/photo/{id}", produces = MediaType.IMAGE_JPEG_VALUE)
	public ResponseEntity<byte[]> get(@PathVariable Long id) {
		try {
			return new ResponseEntity<>(photoService.getById(id), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PostMapping(value="/photo/{id}/like")
	public ResponseEntity<?> like(@PathVariable Long id) {
		try {
			photoService.like(id);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PostMapping("/upload")
	public ResponseEntity<?> uplaodImage(@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {
			photoService.upload(new ArrayList<MultipartFile>(Arrays.asList(files)));
			response.setMessage("Image uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
