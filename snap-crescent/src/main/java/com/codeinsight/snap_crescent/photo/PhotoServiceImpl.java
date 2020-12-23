package com.codeinsight.snap_crescent.photo;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadata;
import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadataRepository;
import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadataService;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailRepository;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailService;
import com.codeinsight.snap_crescent.utils.Constant;

@Service
public class PhotoServiceImpl implements PhotoService {

	@Value("${photo.path}")
	private String PHOTO_PATH;

	@Autowired
	private PhotoMetadataService photoMetadataService;

	@Autowired
	private ThumbnailService thumbnailService;

	@Autowired
	private PhotoRepository photoRepository;

	@Autowired
	private PhotoMetadataRepository photoMetadataRepository;

	@Autowired
	private ThumbnailRepository thumbnailRepository;

	@Transactional
	public void processImages() throws Exception {

		File input = new File(PHOTO_PATH);

		List<File> files = new ArrayList<>();
		readFiles(input, files);

		for (File file : files) {

			if (isAlreadyExist(file)) {
				continue;
			}
			Photo image = new Photo();

			PhotoMetadata photoMetadata = photoMetadataService.extractMetaData(file);
			Thumbnail thumbnail = thumbnailService.generateThumbnail(file);

			photoMetadataRepository.save(photoMetadata);
			thumbnailRepository.save(thumbnail);

			image.setMetaDataId(photoMetadata.getId());
			image.setThumbnailId(thumbnail.getId());

			photoRepository.save(image);
		}

	}

	private void readFiles(File file, List<File> files) {

		if (file.isFile()) {
			files.add(file);
		} else {
			for (File f : file.listFiles()) {
				readFiles(f, files);
			}
		}
	}

	private boolean isAlreadyExist(File file) throws Exception {
		boolean exist = false;
		String fileName = file.getName();
		String modifiedDateString = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).format(file.lastModified());
		Date modifiedDate = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).parse(modifiedDateString);
		if (modifiedDate != null) {
			exist = photoMetadataRepository.existsByNameAndModifiedDate(fileName, modifiedDate);
		}
		return exist;
	}

	@Transactional
	public List<Photo> search() throws Exception {
		return photoRepository.findAll();
	}

	@Override
	public void upload(MultipartFile[] multipartFiles) throws Exception {
		File directory = new File(PHOTO_PATH);
		if (!directory.exists()) {
			directory.mkdir();
		}
		Arrays.asList(multipartFiles).stream().forEach(file -> {
			String path = PHOTO_PATH + file.getOriginalFilename();
			try {
				file.transferTo(new File(path));
			} catch (Exception e) {
				e.printStackTrace();
			}
		});

	}
}
