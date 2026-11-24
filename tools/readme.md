# Workflow
1. Set up the DBCTools config file and import clean DBCs (change the database name each time if you want to import different DBCs to compare them with DBC_diff)
2. Make a dump (export) of your squeaky clean DBCs, or make support tables you'll need first
3. Set up the build-dbc config file and point it at the directories containing your SQL files and/or your testworld server
4. Wait for the tool to finish, then copy the exported DBC files to your client patch

# Tools
- `checks/check_client_limits.py`: checks exported client DBCs against the limits of the stock 3.3.5a Wow.exe that
  crash it (CharSections row order, playable race ids of 22 or more, more than 20 playable races, reputation list
  indexes past 127, EmotesTextSound order). Each check names the Wow.exe function it protects. Folders after the
  first fill in the files the first one lacks:
  `python3 tools/checks/check_client_limits.py /path/to/client/DBFilesClient [/path/to/full/set]`
- `checks/check_customization.py`: checks the customization data of race modpaks (CharSections, CharHairGeosets,
  CharacterFacialHairStyles, CharHairTextures, BarberShopStyle) for missing textures, textures from another race's
  folder, duplicate rows, colour/type gaps and geosets the model lacks. No database needed, but it reads the client
  assets from a [WHE-common](https://github.com/Medviten/WHE-common) checkout (next to this repo by default, or
  `--common PATH` / `$WHE_COMMON`):
  `python3 tools/checks/check_customization.py --stock-dbc /path/to/original/dbc [MODPAK ...]`
