package com.snapcrescent.bulk_import;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponse;

@RestController
public class BulkImportController extends BaseController {

	@Autowired()
	@Qualifier("directory")
	private BulkImportService directoryImportService;
	
	@Autowired
	@Qualifier("google")
	private BulkImportService googleImportService;

	@PostMapping("/bulk-import/directory")
	public ResponseEntity<?> bulkImportFromDirectory(@RequestBody BulkImportRequest  bulkImportRequest) throws IOException {

		BaseResponse response = new BaseResponse();
		try {

			directoryImportService.bulkImport(bulkImportRequest);
			response.setMessage("Asset migrated successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PostMapping("/bulk-import/google-takeout")
	public ResponseEntity<?> bulkImportFromGoogleTakeout(@RequestBody BulkImportRequest  bulkImportRequest) throws IOException {

		BaseResponse response = new BaseResponse();
		try {

			googleImportService.bulkImport(bulkImportRequest);
			response.setMessage("Asset migrated successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}

}
