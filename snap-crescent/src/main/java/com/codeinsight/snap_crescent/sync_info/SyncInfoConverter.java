package com.codeinsight.snap_crescent.sync_info;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

@Component
public class SyncInfoConverter extends BaseConverter<SyncInfo, UiSyncInfo> {

	@Override
	public void populateEntityWithBean(SyncInfo entity, UiSyncInfo bean) {

	}

	@Override
	public SyncInfo getEntityFromBean(UiSyncInfo bean) {

		SyncInfo entity = new SyncInfo();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<SyncInfo> getEntitiesFromBeans(List<UiSyncInfo> beans) {

		List<SyncInfo> entities = new ArrayList<>();

		for (UiSyncInfo bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiSyncInfo> getBeansFromEntities(List<SyncInfo> entities, ResultType resultType) {

		List<UiSyncInfo> beans = new ArrayList<>();

		for (SyncInfo entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiSyncInfo getBeanFromEntity(SyncInfo entity, ResultType resultType) {

		UiSyncInfo bean = new UiSyncInfo();

		try {
			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
