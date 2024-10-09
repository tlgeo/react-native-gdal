import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-gdal' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Gdal = NativeModules.Gdal
  ? NativeModules.Gdal
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

export function getDrivers(): Promise<string[]> {
  return Gdal.getDrivers();
}

export function ogr2ogr(srcPath: string, destPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNOgr2ogr(srcPath, destPath, agrs);
}

export function ogrinfo(srcPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNOgrinfo(srcPath, agrs);
}

export function gdalinfo(srcPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNGdalinfo(srcPath, agrs);
}

export function gdal_translate(srcPath: string, destPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNGdalTranslate(srcPath, destPath, agrs);
}