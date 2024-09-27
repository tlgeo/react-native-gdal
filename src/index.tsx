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

export function multiply(a: number, b: number): Promise<number> {
  return Gdal.multiply(a, b);
}

export function ogr2ogr(agrs: string[]): Promise<string> {
  return Gdal.RNOgr2ogr(agrs);
}

export function ogrinfo(agrs: string[]): Promise<string> {
  return Gdal.RNOgrinfo(agrs);
}

export function gdalinfo(agrs: string[]): Promise<string> {
  return Gdal.RNGdalinfo(agrs);
}

export function gdal_translate(agrs: string[]): Promise<string> {
  return Gdal.RNGdalTranslate(agrs);
}