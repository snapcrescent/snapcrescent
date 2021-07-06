package com.codeinsight.snap_crescent.video;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.appConfig.AppConfigService;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.services.BaseService;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailRepository;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailService;
import com.codeinsight.snap_crescent.videoMetadata.VideoMetadataRepository;
import com.codeinsight.snap_crescent.videoMetadata.VideoMetadataService;

@Service
public class VideoServiceImpl extends BaseService implements VideoService {

	@Autowired
	private VideoMetadataService videoMetadataService;

	@Autowired
	private ThumbnailService thumbnailService;

	@Autowired
	private VideoRepository videoRepository;

	@Autowired
	private VideoMetadataRepository videoMetadataRepository;

	@Autowired
	private ThumbnailRepository thumbnailRepository;

	@Autowired
	private AppConfigService appConfigService;

	@Autowired
	private FileService fileService;

	@Autowired
	private VideoConverter videoConverter;

	@Transactional
	public BaseResponseBean<Long, UiVideo> search(VideoSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiVideo> response = new BaseResponseBean<>();

		int count = videoRepository.count(searchCriteria);

		if (count > 0) {

			List<UiVideo> searchResult = videoConverter.getBeansFromEntities(
					videoRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION),
					searchCriteria.getResultType());

			response.setTotalResultsCount(count);
			response.setResultCountPerPage(searchResult.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(searchResult);

		}

		return response;
	}

	@Override
	@Transactional
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception {

	}

	private boolean isAlreadyExist(File file) throws Exception {
		boolean exist = false;
		String fileName = file.getName();
		exist = videoMetadataRepository.existsByName(fileName);
		return exist;
	}

	@Override
	public UiVideo getById(Long id) {
		return videoConverter.getBeanFromEntity(videoRepository.findById(id), ResultType.FULL);
	}

	@Override
	@Transactional
	public File getVideoById(Long id) throws Exception {
		Video video = videoRepository.findById(id);
		String fileUniqueName = video.getVideoMetadata().getPath();
		return fileService.getFile(FILE_TYPE.VIDEO, fileUniqueName);
	}

	@Override
	@Transactional
	public void update(UiVideo enity) throws Exception {
		// TODO Auto-generated method stub

	}

}
