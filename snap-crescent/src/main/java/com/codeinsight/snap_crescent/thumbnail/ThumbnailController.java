package com.codeinsight.snap_crescent.thumbnail;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ThumbnailController {

	@Autowired
	private ThumbnailService thumbnailService;

	@GetMapping("/thumbnail/{id}")
	public ResponseEntity<byte[]> get(@PathVariable Long id) {
		try {
			return new ResponseEntity<>(thumbnailService.getById(id), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

}
