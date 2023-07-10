package com.snapcrescent.album;

import java.util.List;
import java.util.UUID;

import org.modelmapper.Converter;
import org.modelmapper.TypeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;
import com.snapcrescent.common.utils.Constant.DbEnum;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.ModelMapperUtils;
import com.snapcrescent.user.User;
import com.snapcrescent.user.UserConverter;

@Component
public class AlbumConverter extends BaseConverter<Album, UiAlbum> {

	@Autowired
	private AlbumRepository albumRepository;

	@Autowired
	private UserConverter userConverter;

	public AlbumConverter() {
		super(Album.class, UiAlbum.class);
	}

	@Override
	public Album loadEntityById(Long id) {
		return albumRepository.loadById(id);
	}

	@Override
	public void populateEntityWithBean(Album entity, UiAlbum bean) {

		String typeMapName = UUID.randomUUID().toString();
		TypeMap<UiAlbum, Album> typeMap = getBeanToEntityMapper(typeMapName);

		// Mapping questions via custom method to avoid hibernate expections
		typeMap.addMappings(mapper -> mapper.skip(UiAlbum::getUsers, Album::setUsers));

		List<User> persistedChildren = userConverter.processCollectionUpdate(entity.getUsers(), bean.getUsers(), false);

		super.populateEntityWithBean(entity, bean, typeMapName);

		if (entity.getUsers() == null) {
			entity.setUsers(persistedChildren);
		}

	}

	@Override
	public List<UiAlbum> getBeansFromEntities(List<Album> entities, ResultType resultType) {
		return super.getBeansFromEntities(entities, resultType, createTypeMap(resultType));
	}

	@Override
	public UiAlbum getBeanFromEntity(Album entity, ResultType resultType) {
		UiAlbum bean = super.getBeanFromEntity(entity, resultType, createTypeMap(resultType));

		if (resultType == ResultType.FULL) {
			bean.setUsers(userConverter.getBeansFromEntities(entity.getUsers(), resultType));
		}

		return bean;
	}

	private String createTypeMap(ResultType resultType) {

		String typeMapName = UUID.randomUUID().toString();
		TypeMap<Album, UiAlbum> typeMap = getEntityToBeanMapper(typeMapName);

		Converter<DbEnum, String> enumConvertor = ModelMapperUtils.getDbEnumConvertor();
		
		typeMap.addMappings(mapper -> mapper.using(enumConvertor).map(Album::getAlbumTypeEnum, UiAlbum::setAlbumTypeName));
		
		//Skipping users because users are never needed on album screen and it will be fetched via custom method
		typeMap.addMappings(mapper -> mapper.skip(Album::getUsers, UiAlbum::setUsers));

		return typeMapName;
	}

}
