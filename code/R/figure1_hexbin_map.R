# ==============================================================================
# figure1_hexbin_map.R
#
# Figure 1: Geographic and temporal variation in ENDS taxes, 2010-2023.
# Hexbin maps of the real closed-system ENDS tax per mL (2023$), annual average.
#
# Usage (from the repository root):
#   Rscript code/R/figure1_hexbin_map.R <path_repo> <path_data>
# path_data is the folder that contains clean/controls_quarterly.dta.
#
# Packages: haven, dplyr, ggplot2, sf, cowplot, tilegramsR
# ==============================================================================

library(haven)
library(dplyr)
library(ggplot2)
library(sf)
library(cowplot)
library(tilegramsR)

args      <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript code/R/figure1_hexbin_map.R <path_repo> <path_data>")
path_repo <- args[1]
path_data <- args[2]

controls_path <- file.path(path_data, "clean", "controls_quarterly.dta")
output_path   <- file.path(path_repo, "output", "figures")

fips_lookup <- data.frame(
  state_fips = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,
                 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,
                 40,41,42,44,45,46,47,48,49,50,51,53,54,55,56),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA",
                 "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA",
                 "MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY",
                 "NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX",
                 "UT","VT","VA","WA","WV","WI","WY")
)

# Annual average tax by state; zero means no tax
data_annual <- read_dta(controls_path) %>%
  group_by(state_fips, year) %>%
  summarise(ends_tax = mean(ends_tax_nom35_closed, na.rm = TRUE), .groups = "drop") %>%
  mutate(ends_tax = if_else(ends_tax == 0, NA_real_, ends_tax)) %>%
  left_join(fips_lookup, by = "state_fips")

# NPR one-hexagon-per-state tilegram
hexbin_sf <- sf_NPR1to1 %>% rename(state_abbr = state)

tax_breaks <- c(0, 1, 2, 3, 4)
tax_labels <- c("($0.00,$1.00]", "($1.00,$2.00]", "($2.00,$3.00]", "($3.00,$4.00]")
cat_levels <- c("($3.00,$4.00]", "($2.00,$3.00]", "($1.00,$2.00]",
                "($0.00,$1.00]", "[$0.00]")
cat_fills  <- c("($3.00,$4.00]" = "grey10",
                "($2.00,$3.00]" = "grey35",
                "($1.00,$2.00]" = "grey65",
                "($0.00,$1.00]" = "grey88",
                "[$0.00]"       = "white")

make_hex_map <- function(yr, data, hex_sf, show_legend = FALSE) {
  map_data <- hex_sf %>%
    left_join(filter(data, year == yr), by = "state_abbr") %>%
    mutate(
      tax_bin  = cut(ends_tax, breaks = tax_breaks, labels = tax_labels,
                     include.lowest = FALSE, right = TRUE),
      fill_cat = factor(if_else(!is.na(tax_bin), as.character(tax_bin), "[$0.00]"),
                        levels = cat_levels),
      # untaxed states get a dashed border
      btype    = if_else(is.na(ends_tax), "dashed", "solid")
    )

  ggplot(map_data) +
    geom_sf(aes(fill = fill_cat, linetype = btype), color = "grey40", linewidth = 0.35) +
    geom_sf_text(aes(label = state_abbr,
                     color = fill_cat %in% c("($3.00,$4.00]", "($2.00,$3.00]")),
                 size = 1.8, fontface = "bold") +
    scale_color_manual(values = c("TRUE" = "white", "FALSE" = "grey20"), guide = "none") +
    scale_fill_manual(
      name   = "Real ENDS Tax in 2023$",
      values = cat_fills,
      drop   = FALSE,
      guide  = guide_legend(
        direction = "horizontal", title.position = "top", title.hjust = 0.5,
        label.position = "bottom", nrow = 1,
        override.aes = list(linetype = c("solid", "solid", "solid", "solid", "dashed"))
      )
    ) +
    scale_linetype_manual(values = c("solid" = "solid", "dashed" = "dashed"), guide = "none") +
    labs(title = as.character(yr)) +
    theme_void(base_size = 9) +
    theme(
      plot.title        = element_text(hjust = 0.5, size = 10, margin = margin(b = 2)),
      legend.position   = if (show_legend) "bottom" else "none",
      legend.title      = element_text(size = 8),
      legend.text       = element_text(size = 7.5),
      legend.key.width  = unit(1.3, "lines"),
      legend.key.height = unit(0.9, "lines"),
      legend.spacing.x  = unit(0.2, "lines")
    )
}

years <- c(2010, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2023)
maps  <- lapply(years, make_hex_map, data = data_annual, hex_sf = hexbin_sf)
legend_grob <- get_legend(make_hex_map(2021, data_annual, hexbin_sf, show_legend = TRUE))

final_figure <- plot_grid(
  plot_grid(plotlist = maps, nrow = 3, ncol = 3, align = "hv", axis = "tblr"),
  legend_grob,
  ncol = 1, rel_heights = c(0.92, 0.08)
)

for (d in c("png", "pdf")) dir.create(file.path(output_path, d), recursive = TRUE, showWarnings = FALSE)
ggsave(file.path(output_path, "pdf", "figure1.pdf"), plot = final_figure,
       width = 10, height = 8, units = "in", bg = "white")
ggsave(file.path(output_path, "png", "figure1.png"), plot = final_figure,
       width = 10, height = 8, units = "in", dpi = 300, bg = "white")
