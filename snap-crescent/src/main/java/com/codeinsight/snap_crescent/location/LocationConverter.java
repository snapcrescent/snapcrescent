package com.codeinsight.snap_crescent.location;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

@Component
public class LocationConverter extends BaseConverter<Location, UiLocation>{
	
	@Override
	public void populateEntityWithBean(Location entity, UiLocation bean) {
		
	}

	@Override
	public Location getEntityFromBean(UiLocation bean) {

		Location entity = new Location();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Location> getEntitiesFromBeans(List<UiLocation> beans) {

		List<Location> entities = new ArrayList<>();

		for (UiLocation bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiLocation> getBeansFromEntities(List<Location> entities, ResultType resultType) {

		List<UiLocation> beans = new ArrayList<>();

		for (Location entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiLocation getBeanFromEntity(Location entity, ResultType resultType) {

		UiLocation bean = new UiLocation();

		try {
			bean.setLongitude(entity.getLongitude());
			bean.setLatitude(entity.getLatitude());
			bean.setCountry(entity.getCountry());
			bean.setState(entity.getState());
			bean.setCity(entity.getCity());
			bean.setTown(entity.getTown());
			bean.setPostcode(entity.getPostcode());
			
			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
