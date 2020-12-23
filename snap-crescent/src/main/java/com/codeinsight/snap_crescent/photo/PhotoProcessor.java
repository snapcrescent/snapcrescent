package com.codeinsight.snap_crescent.photo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class PhotoProcessor {

	@Autowired
	private PhotoService photoService;

	@Scheduled(cron = "${cron.photo.process}")
	public void processImages() {

		try {
			photoService.processImages();
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
