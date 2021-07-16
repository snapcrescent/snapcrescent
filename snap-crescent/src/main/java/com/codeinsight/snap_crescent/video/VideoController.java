package com.codeinsight.snap_crescent.video;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.BaseController;
import com.codeinsight.snap_crescent.common.beans.BaseResponse;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

import reactor.core.publisher.Mono;

@RestController
public class VideoController extends BaseController {

	@Autowired
	private VideoService videoService;

	@GetMapping("/video")
	public @ResponseBody BaseResponseBean<Long, UiVideo> search(@RequestParam Map<String, String> searchParams) {
		VideoSearchCriteria searchCriteria = new VideoSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return videoService.search(searchCriteria);

	}

	private void parseSearchParams(Map<String, String> searchParams, VideoSearchCriteria searchCriteria) {

		parseCommonSearchParams(searchParams, searchCriteria);

		if (searchParams.get("favorite") != null) {
			searchCriteria.setFavorite(Boolean.parseBoolean(searchParams.get("favorite")));
		}

		if (searchParams.get("month") != null) {
			searchCriteria.setMonth(searchParams.get("month"));
		}

		if (searchParams.get("year") != null) {
			searchCriteria.setYear(searchParams.get("year"));
		}
	}

	@GetMapping("/video/{id}")
	public @ResponseBody BaseResponseBean<Long, UiVideo> get(@PathVariable Long id) {
		BaseResponseBean<Long, UiVideo> response = new BaseResponseBean<>();
		response.setObjectId(id);
		response.setObject(videoService.getById(id));
		return response;
	}

	@GetMapping(value = "/video/{id}/raw")
	public Mono<ResponseEntity<byte[]>> streamVideo(@RequestHeader(value = "Range", required = false) String httpRangeList, @PathVariable Long id) {
		
		long rangeStart = 0;
        long rangeEnd = 0;
        byte[] data = null;
        long fileSize = 0;
        
		try {

			File file = videoService.getVideoById(id);
			if (!file.isFile()) {
				return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
			}
			
			fileSize = file.length();
            if (httpRangeList == null) {
                return Mono.just(ResponseEntity.status(HttpStatus.OK)
                        .header("Content-Type", "video/mp4")
                        .header("Content-Length", String.valueOf(fileSize))
                        .body(readByteRange(file, rangeStart, fileSize - 1))); // Read the object and convert it as bytes
            }
            String[] ranges = httpRangeList.split("-");
            rangeStart = Long.parseLong(ranges[0].substring(6));
            if (ranges.length > 1) {
                rangeEnd = Long.parseLong(ranges[1]);
            } else {
                rangeEnd = fileSize - 1;
            }
            if (fileSize < rangeEnd) {
                rangeEnd = fileSize - 1;
            }
            data = readByteRange(file, rangeStart, rangeEnd);

		} catch (Exception e) {
			e.printStackTrace();
		}
		
		String contentLength = String.valueOf((rangeEnd - rangeStart) + 1);
        return Mono.just(ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
        		.header("Content-Type", "video/mp4")
                .header("Accept-Ranges", "bytes")
                .header("Content-Length", contentLength)
                .header("Content-Range", "bytes " + rangeStart + "-" + rangeEnd + "/" + fileSize)
                .body(data));
		
	}
	
	public byte[] readByteRange(File file, long start, long end) throws IOException {
        Path path = Paths.get(file.getAbsolutePath());
        try (InputStream inputStream = (Files.newInputStream(path));
             ByteArrayOutputStream bufferedOutputStream = new ByteArrayOutputStream()) {
            byte[] data = new byte[1024];
            int nRead;
            while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                bufferedOutputStream.write(data, 0, nRead);
            }
            bufferedOutputStream.flush();
            byte[] result = new byte[(int) (end - start) + 1];
            System.arraycopy(bufferedOutputStream.toByteArray(), (int) start, result, 0, result.length);
            return result;
        }
    }

	@PutMapping(value = "/video/{id}")
	public ResponseEntity<?> update(@PathVariable Long id, @RequestBody UiVideo video) {
		try {
			// videoService.like(id);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PostMapping("/video/upload")
	public ResponseEntity<?> uplaodVideo(@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {
			videoService.upload(new ArrayList<MultipartFile>(Arrays.asList(files)));
			response.setMessage("Video uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
