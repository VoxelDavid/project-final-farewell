--[[

]]

repeat wait() until _G.ready

local Data = require(_G.modules.Data)

--[[
  Takes the version string and seperates each part into a key/value pair in
  a table. Eg. "v0.1.0-alpha.1" would be turned into:

  {
    "full" = "v0.1.0-alpha.1",
    "major" = 0,
    "minor" = 1,
    "patch" = 0,
    "alpha" = 1,
    "prerelease" = true
  }
]]
function convertVersionToTable(fullVersion)
  -- fullVersion = "v0.1.0-alpha.1"
  local versionNumber = fullVersion:match("v%d\.%d\.%d") -- "v0.1.0"
  local prereleaseVersion = fullVersion:match("\-%a*\.%d") -- "-alpha.1"

  local versionTable = {
    full = fullVersion
  }

  function majorMinorPatch()
    -- Is there a method I can use to accomplish this
    -- without an iterator variable?
    local iterator = 0
    for digit in versionNumber:gmatch("%d") do
      if iterator == 0 then
        versionTable.major = digit
      elseif iterator == 1 then
        versionTable.minor = digit
      elseif iterator == 2 then
        versionTable.patch = digit
      end

      iterator = iterator +1
    end
  end

  function prerelease()
    local prereleaseName = prereleaseVersion:match("%a+") -- alpha
    local prereleaseNumber = prereleaseVersion:match("%d") -- 1

    versionTable[prereleaseName] = prereleaseNumber

    -- A value used to check if the current version is a prerelease
    -- without needing to look for "alpha" or "beta" strings.
    versionTable.prerelease = true
  end

  majorMinorPatch()

  if prereleaseVersion then
    prerelease()
  end

  return versionTable
end

function latestSemanticVersion()
  local currentVersion = convertVersionToTable(_G.version)
  local latestVersion = convertVersionToTable(Data:get("Server", "version"))

  local majorUpdated
  local minorUpdated

  function compareMajor(current, latest)
    if current.major > latest.major then
      -- MAJOR was updated.
      majorUpdated = true
      return true
    elseif current.major == latest.major then
      -- MAJOR is the same as latest.
      return true
    else
      return false
    end
  end

  function compareMinor(current, latest)
    if current.minor < latest.minor and majorUpdated == true then
      -- MINOR decreased in value, MAJOR was updated.
      minorUpdated = true
      return true
    elseif current.minor > latest.minor then
      -- MINOR went up in value
      minorUpdated = true
      return true
    elseif current.minor == latest.minor then
      -- MINOR is the same as latest.
      return true
    else
      return false
    end
  end

  function comparePatch(current, latest)
    if current.patch < latest.patch and minorUpdated == true then
      -- PATCH decreased in value, MINOR was updated.
      return true
    elseif current.patch > latest.patch then
      -- PATCH is greater than latest.
      return true
    else
      return false
    end
  end

  function compareVersions(current, latest)
    local major = compareMajor(current, latest)
    local minor = compareMinor(current, latest)
    local patch = comparePatch(current, latest)

    -- print(major, minor, patch)

    if major and minor and patch then
      return true
    else
      return false
    end
  end

  return compareVersions(currentVersion, latestVersion)
end

