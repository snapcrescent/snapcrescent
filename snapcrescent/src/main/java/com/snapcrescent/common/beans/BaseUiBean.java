package com.snapcrescent.common.beans;

import java.io.Serializable;

import lombok.Data;

@Data
public abstract class BaseUiBean implements Serializable {

	private static final long serialVersionUID = 6486192088436426369L;

	protected Long id;
	

}
