package com.codeinsight.snap_crescent.album;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AlbumController {

	@Autowired
	private AlbumService albumService;

	@GetMapping("/album")
	public ResponseEntity<?> search(@RequestParam Map<String, String> searchParams) {

		AlbumSearchCriteria searchCriteria = new AlbumSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		String msg = "";
		try {
			return new ResponseEntity<>(albumService.search(searchCriteria), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			msg = e.getMessage();
		}
		return new ResponseEntity<>(msg, HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	private void parseSearchParams(Map<String, String> searchParams, AlbumSearchCriteria searchCriteria) {

		if (searchParams.get("page") != null) {
			searchCriteria.setPage(Integer.parseInt(searchParams.get("page")));
		}
		
		if (searchParams.get("size") != null) {
			searchCriteria.setSize(Integer.parseInt(searchParams.get("size")));
		}
	}
	
	@PostMapping("/album")
	public ResponseEntity<?> create(Album album) {
		String msg = "";
		try {
			albumService.create(album);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			msg = e.getMessage();
		}
		return new ResponseEntity<>(msg, HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
