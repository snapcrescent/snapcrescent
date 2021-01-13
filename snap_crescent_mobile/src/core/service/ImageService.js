import store from "..";
import { getData, getHeaders, getImage } from "./ApiService";

const IMAGE_URL = 'photo';

export const searchImage = (searchParams) => {
    const serverUrl = store.getState().serverUrl;
    searchParams = {
        page: 0,
        size: 50,
        ...searchParams
    };
    return getData(IMAGE_URL, searchParams).then(res => {
        const images = res.content.map((item, index) => {
            return {
                id: item.id,
                createdDate: item.metadata.createdDate,
                device: item.metadata.model ? item.metadata.model : 'Unknown',
                size: item.metadata.size,
                thumbnailSource: {
                    uri: serverUrl + "/thumbnail/" + item.thumbnailId,
                    headers: {
                        ...getHeaders(true),
                        responseType: 'blob'
                    }
                }
            }
        });

        return images;
    });
}

export const getImageById = (imageId) => {
    return getImage(IMAGE_URL + '/' + imageId);
}