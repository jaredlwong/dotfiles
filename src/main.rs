/// A lot of this comes from: https://github.com/9999years/today_tmp/blob/main/src/lib.rs
use cmd_lib::run_fun;
use color_eyre::eyre::{self, eyre, ContextCompat, WrapErr};
use std::{
    ffi::OsString,
    fmt::Debug,
    fs,
    io::{self},
    os::unix,
    path::{Path, PathBuf},
};
// use time::{format_description, OffsetDateTime};
use tracing::{debug, info, span, Level};
// use tracing::{debug, error, event, info, instrument, span, warn, Level};
use tracing_subscriber;

// extern crate pretty_env_logger;
// #[macro_use]
// extern crate log;

pub static DATE_FMT: &str = "%Y-%m-%d";
// static FILENAME_DATETIME_FMT: &str = "%Y-%m-%dT%H_%M_%S";
static FILENAME_DATETIME_FMT: &str = "%Y-%m-%dT%H_%M_%S";

// const FILENAME_DATETIME_FMT: &'static str = "[year]-[month]-[day]-[hour]:[minute]:[second]";

fn main() -> eyre::Result<()> {
    // tracing_subscriber::fmt::init();
    install_tracing();
    // pretty_env_logger::init();

    color_eyre::install()?;

    let repodir = run_fun!(git rev-parse --show-toplevel)?;
    let repopath = Path::new(&repodir);
    let home = dirs::home_dir()
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "$HOME not found"))?;

    let xdg_dirs = xdg::BaseDirectories::new()?;

    ensure_symlink(
        &Path::join(repopath, Path::new("home/.zshenv")),
        &Path::join(&home, Path::new(".zshenv")),
    )?;

    ensure_symlink(
        &Path::join(repopath, Path::new("zsh")),
        &Path::join(&xdg_dirs.get_config_home(), "zsh"),
    )?;

    ensure_symlink(
        &Path::join(repopath, Path::new("brew")),
        &Path::join(&xdg_dirs.get_config_home(), "brew"),
    )?;

    ensure_symlink(
        &Path::join(repopath, Path::new("starship")),
        &Path::join(&xdg_dirs.get_config_home(), "starship"),
    )?;

    ensure_symlink(
        &Path::join(repopath, Path::new("nvim")),
        &Path::join(&xdg_dirs.get_config_home(), "nvim"),
    )?;

    ensure_symlink(
        &Path::join(repopath, Path::new("asdf")),
        &Path::join(&xdg_dirs.get_config_home(), "asdf"),
    )?;

    Ok(())
}

fn install_tracing() {
    use tracing_error::ErrorLayer;
    use tracing_subscriber::fmt::{self, format::FmtSpan};
    use tracing_subscriber::prelude::*;
    use tracing_subscriber::EnvFilter;

    let fmt_layer = fmt::layer()
        .with_target(false)
        .with_span_events(FmtSpan::ACTIVE);
    let filter_layer = EnvFilter::try_from_default_env().unwrap();

    tracing_subscriber::registry()
        .with(filter_layer)
        .with(fmt_layer)
        .with(ErrorLayer::default())
        .init();
}

fn pathbuf_to_string(pathbuf: &Path) -> eyre::Result<String> {
    Ok(pathbuf
        .as_os_str()
        .to_str()
        .ok_or_else(|| eyre!("couldn't get path"))
        .map(str::to_string)?)
}

pub fn ensure_symlink(original: &Path, link: &Path) -> eyre::Result<()> {
    let original_str = pathbuf_to_string(original)?;
    let link_str = pathbuf_to_string(link)?;

    debug!("ensuring symlink exists: {} -> {}", link_str, original_str);

    fs::symlink_metadata(original)
        .wrap_err_with(|| format!("error calling stat on original: {original_str}"))?;

    let canonical_original = original
        .canonicalize()
        .wrap_err("Failed to canonicalize path")?;
    let canonical_original_str = pathbuf_to_string(&canonical_original)?;

    let needs_backup: bool = match (
        fs::symlink_metadata(link),
        fs::read_link(link).and_then(std::fs::canonicalize),
    ) {
        (Ok(ref stat), Ok(ref target)) => {
            if stat.file_type().is_symlink() && target == &canonical_original {
                debug!("symlink already exists: {link_str} -> {canonical_original_str}");
                return Ok(());
            } else {
                debug!(
                    "symlink pointing to different path: {link_str} -> {}",
                    pathbuf_to_string(target)?
                );
                true
            }
        }
        (Ok(_), Err(_)) => {
            debug!("file exists but isn't a symlink: {link_str}");
            true
        }
        (Err(ref e), Err(_)) if e.kind() == io::ErrorKind::NotFound => false,
        _ => {
            return Err(eyre!("Can't stat {link_str}"));
        }
    };

    if needs_backup {
        backup_path(link)?;
    }

    match unix::fs::symlink(original, link) {
        Ok(()) => {
            info!("created symlink: {link_str} -> {original_str}");
            Ok(())
        }
        Err(e) => {
            if e.kind() == io::ErrorKind::AlreadyExists {
                match fs::read_link(link) {
                    Ok(ref path) if Path::new(path) == original => {
                        debug!("symlink already exists: {link_str} -> {original_str}");
                        Ok(())
                    }
                    Ok(path) => Err(eyre!("symlink not correct: {}", pathbuf_to_string(&path)?)),
                    Err(_) => Err(eyre!("reading symlink failed")),
                }
            } else {
                Err(eyre!(
                    "error creating symlink: {link_str} -> {original_str}"
                ))
            }
        }
    }
}

fn backup_path(path: impl AsRef<Path> + Debug) -> eyre::Result<PathBuf> {
    let backup_path = get_backup_path(&path)
        .wrap_err_with(|| format!("Failed to get backup path for {:?}", &path))?;
    let span =
        span!(Level::WARN, "Renaming to avoid name collision", from = ?&path, to = ?&backup_path);
    let _guard = span.enter();
    std::fs::rename(&path, &backup_path)
        .wrap_err_with(|| format!("Failed to rename {:?} to {:?}", &path, &backup_path))?;
    Ok(backup_path)
}

fn get_backup_path(path: impl AsRef<Path> + Debug) -> eyre::Result<PathBuf> {
    let basename = path
        .as_ref()
        .file_name()
        .wrap_err_with(|| format!("Failed to get basename of {:?}", &path))?;
    let append = format!("{}", chrono::Local::now().format(FILENAME_DATETIME_FMT));
    let new_basename = {
        let mut ret = OsString::new();
        ret.push(basename);
        ret.push("-");
        ret.push(append);
        ret
    };

    let mut new_path = path.as_ref().with_file_name(&new_basename);
    let mut i = 0;
    while new_path.exists() {
        i += 1;
        let new_basename = {
            let mut ret = OsString::with_capacity(new_basename.len() + 2);
            ret.push(format!("-{}", i));
            ret
        };
        new_path = path.as_ref().with_file_name(new_basename);
    }

    Ok(new_path)
}
