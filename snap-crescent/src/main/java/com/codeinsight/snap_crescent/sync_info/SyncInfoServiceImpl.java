package com.codeinsight.snap_crescent.sync_info;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

@Service
public class SyncInfoServiceImpl implements SyncInfoService{
	
	@Autowired
	private SyncInfoConverter syncInfoConverter;

	@Autowired
	private SyncInfoRepository syncInfoRepository;
	
	@Transactional
	public BaseResponseBean<Long, UiSyncInfo> search(SyncInfoSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiSyncInfo> response = new BaseResponseBean<>();

		int count = syncInfoRepository.count(searchCriteria);

		if (count > 0) {

			List<UiSyncInfo> searchResult = syncInfoConverter.getBeansFromEntities(
					syncInfoRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION),
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
	public void create(SyncInfo syncInfo) throws Exception {
		syncInfoRepository.save(syncInfo);
		
	}

	@Override
	@Transactional
	public void update(SyncInfo syncInfo) throws Exception {
		syncInfoRepository.save(syncInfo);
	}

	@Override
	@Transactional
	public UiSyncInfo getById(Long id) {
		return syncInfoConverter.getBeanFromEntity(syncInfoRepository.findById(id), ResultType.FULL) ;
	}

}
