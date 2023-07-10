package com.snapcrescent.user;

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

@Component
public class UserConverter extends BaseConverter<User, UiUser> {

	@Autowired
	private UserRepository userRepository;
	
	public UserConverter() {
		super(User.class, UiUser.class);
	}

	@Override
	public User loadEntityById(Long id) {
		return userRepository.loadById(id);
	}
	
	@Override
	public List<UiUser> getBeansFromEntities(List<User> entities, ResultType resultType) {
		return super.getBeansFromEntities(entities, resultType, createTypeMap(resultType));
	}

	@Override
	public UiUser getBeanFromEntity(User entity, ResultType resultType) {
		return super.getBeanFromEntity(entity, resultType, createTypeMap(resultType)); 
	}

	private String createTypeMap(ResultType resultType) {

		String typeMapName = UUID.randomUUID().toString();
		TypeMap<User, UiUser> typeMap = getEntityToBeanMapper(typeMapName);

		Converter<DbEnum, String> enumConvertor = ModelMapperUtils.getDbEnumConvertor();

		typeMap.addMappings(mapper -> mapper.using(enumConvertor).map(User::getUserTypeEnum, UiUser::setUserTypeName));
		

		return typeMapName;
	}
}
