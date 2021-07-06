package com.codeinsight.snap_crescent.sync_info;

import javax.persistence.Entity;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "SYNC_INFO")
@Data
@EqualsAndHashCode(callSuper = false)
public class SyncInfo extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;
}
