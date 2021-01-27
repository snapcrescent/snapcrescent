import store from "..";
import { getData, getFile, getHeaders } from "./ApiService";

const PHOTO_URL = 'photo';

export const searchPhoto = (searchParams) => {
    const serverUrl = store.getState().serverUrl;
    searchParams = {
        page: 0,
        size: 500,
        ...searchParams
    };
    return getData(PHOTO_URL, searchParams).then(res => {
        const photos = res.content.map((item, index) => {
            return {
                id: item.id,
                createdDate: item.metadata.createdDate,
                device: item.metadata.model ? item.metadata.model : 'Unknown',
                size: item.metadata.size,
                thumbnailSource: {
                    uri: 'data:image/*;base64,' + item.base64EncodedThumbnail
                }
            }
        });

        return photos;
    });
}

export const getPhotoById = (imageId) => {
    return getFile(PHOTO_URL + '/' + imageId);
}