package com.codeinsight.snap_crescent.thumbnail;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "thumbnail")
@Data
@EqualsAndHashCode(callSuper = false)
public class Thumbnail extends BaseEntity {

	private static final long serialVersionUID = 1567235158787189351L;

	@Column(nullable = false)
	private String name;

	@Column(nullable = false)
	private String path;
}
