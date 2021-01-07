package com.codeinsight.snap_crescent.photo;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadata;
import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadataRepository;
import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadataService;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailRepository;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailService;

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
	public Page<Photo> search(PhotoSearchCriteria photoSearchCriteria) throws Exception {
		Pageable pageable = PageRequest.of(photoSearchCriteria.getPage(), photoSearchCriteria.getSize());
		return photoRepository.search(pageable);
	}

	@Override
	@Transactional
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception {
		File directory = new File(PHOTO_PATH);
		if (!directory.exists()) {
			directory.mkdir();
		}
		for (MultipartFile multipartFile : multipartFiles) {
			String path = PHOTO_PATH + multipartFile.getOriginalFilename();
			multipartFile.transferTo(new File(path));

			File file = new File(path);
			if (isAlreadyExist(file)) {
				continue;
			}
			Photo image = new Photo();

			PhotoMetadata photoMetadata = photoMetadataService.extractMetaData(file);
			Thumbnail thumbnail = thumbnailService.generateThumbnail(file, photoMetadata);

			photoMetadataRepository.save(photoMetadata);
			thumbnailRepository.save(thumbnail);

			image.setMetaDataId(photoMetadata.getId());
			image.setThumbnailId(thumbnail.getId());

			photoRepository.save(image);

		}

	}

	private boolean isAlreadyExist(File file) throws Exception {
		boolean exist = false;
		String fileName = file.getName();
		exist = photoMetadataRepository.existsByName(fileName);
		return exist;
	}

	@Override
	@Transactional
	public byte[] getById(Long id) throws Exception {
		Photo photo = photoRepository.findById(id).get();
		String path = photo.getMetadata().getPath();
		File file = new File(path);
		byte[] image = null;
		try {
			InputStream in = new FileInputStream(file);
			image = IOUtils.toByteArray(in);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return image;
	}
}
