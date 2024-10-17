# React Native GDAL

React Native GDAL provides a bridge to the Geospatial Data Abstraction Library (GDAL) for React Native projects, enabling geospatial data manipulation and conversion functionalities directly from React Native apps. This library supports basic GDAL operations like retrieving driver information, converting formats, getting file info, and more.

## Features

- List supported GDAL drivers.
- Convert geospatial data formats using `ogr2ogr`.
- Retrieve data source information using `ogrinfo`.
- Get detailed file information using `gdalinfo`.
- Convert file formats with `gdal_translate`.
- Generate raster overviews using `gdal_addo`.
- Set the `proj.db` path on Android devices.

## Installation

```bash
npm install @tlgeo/react-native-gdal
```
or
```bash
yarn add @tlgeo/react-native-gdal
```

## Usage
### Importing the module
```JavaScript
import * as Gdal from '@tlgeo/react-native-gdal';
```
### Get supported drivers
```JavaScript
Gdal.getDrivers().then(drivers => {
  console.log(drivers);
});
```
### Convert Between Vector File Formats with <code>ogr2ogr</code>
```JavaScript
const srcPath = 'path/to/source/file';
const destPath = 'path/to/destination/file';
const args = ['arg1', 'arg2'];

Gdal.ogr2ogr(srcPath, destPath, args).then(result => {
  console.log(result);
});
```
### Get Vector Data Source Information with `ogrinfo`
```JavaScript
const srcPath = 'path/to/source/file';
const args = ['arg1', 'arg2'];

Gdal.ogrinfo(srcPath, args).then(info => {
  console.log(info);
});
```
### Get Raster File Information with `gdalinfo`
```JavaScript
const srcPath = 'path/to/source/file';
const args = ['arg1', 'arg2'];

Gdal.gdalinfo(srcPath, args).then(info => {
  console.log(info);
});
```
### Convert Between Raster File Formats with `gdal_translate`
```JavaScript
const srcPath = 'path/to/source/file';
const destPath = 'path/to/destination/file';
const args = ['arg1', 'arg2'];

Gdal.gdal_translate(srcPath, destPath, args).then(result => {
  console.log(result);
});
```
### Setting Android Projection Library Path
```JavaScript
const path = 'path/to/proj.db';

Gdal.setAndroidProjLibPath(path);
```
### Platform Specific Notes
The <code>setAndroidProjLibPath</code> function is only functional on Android devices. Ensure the <code>proj.db</code> file is copied from your assets folder to the app's data folder before setting the path.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your features, fixes, or improvements.

## License
[MIT](https://mit-license.org/)