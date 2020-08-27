
#' @importFrom dplyr %>% select group_by summarise
conditionalCumSum <- function(grp_,dat,X,Y){
  v1 = dat %>% select(c(X,Y)) %>%
    group_by(.dots = c(X,Y)) %>% summarise(n2 = n())
  v2 = merge(grp_,v1, by = c(X,Y))
  v2$n = v2$n / v2$n2 * 100
  return (v2)
}


#' @import ggplot2
#' @importFrom ggplot2 aes
#' @importFrom dplyr %>% select group_by summarise
fs1.1b = function(dat,X,Y,N_,obs.y,iscat = T, freqz = F,
                  pc = F, jW = 0.35, jH = 0.35, NoCls = F, limits = NULL, plot.Trend = F, method = "auto"){
  if(NoCls){
    dat$obs_u_01_a = "One Class"
    C_IND = ""
  } else {
    dat$obs_u_01_a = dat[[obs.y]]
    C_IND = obs.y
  }


  if (iscat){

    if(freqz){

      grp_ =  dat %>% select(c(X,Y,"obs_u_01_a")) %>%
        group_by(.dots = c(X,Y,"obs_u_01_a")) %>% summarise(n = n())

      if (pc){
        grp_ = conditionalCumSum(grp_,dat,X,Y)
      }



      grp_$obs_u_01_a = as.factor(grp_$obs_u_01_a)
      msg_ = paste0("Group ",N_,"  = ", dat$Group[1])
      msg__ = paste0("Facet =  ",Y)
      fplot <- ggplot2::ggplot(data = grp_)+ggplot2::geom_bar(stat = "identity",position = "dodge",ggplot2::aes_string(
        x = X , y = "n", fill = "obs_u_01_a")
      ) + ggplot2::xlab(X) + ggplot2::ylab("") +  ggplot2::facet_wrap(reformulate(Y) , drop=T) + ggplot2::coord_flip() +
        ggplot2::labs(title = msg_,subtitle = msg__ , fill = C_IND) + ggplot2::theme_classic()

      return (fplot)



    }

    msg_ = paste0("Group ",N_,"  = ", dat$Group[1])
    fplot <- ggplot2::ggplot()+ggplot2::geom_point(ggplot2::aes(
      x = as.factor(dat[[X]]) , y = as.factor(dat[[Y]]), color = as.factor(dat[["obs_u_01_a"]])),
      position = ggplot2::position_jitter(w = jW, h = jH)) + ggplot2::xlab(X) + ggplot2::ylab(Y) + ggplot2::ggtitle(msg_) +
      ggplot2::labs(color = C_IND) + ggplot2::theme_classic()

    return (fplot)
  }else{

    if (!plot.Trend){
      msg_ = paste0("Group ",N_,"  = ", dat$Group[1])
      fplot <- ggplot2::ggplot()+ggplot2::geom_point(ggplot2::aes(
        x = dat[[X]] , y = dat[[Y]], color = as.factor(dat[["obs_u_01_a"]])),
        position = ggplot2::position_jitter(w = jW, h = jH)) + ggplot2::xlab(X) +
        ggplot2::ylab(Y) + ggplot2::ggtitle(msg_) + ggplot2::labs(color = C_IND) + ggplot2::theme_classic()
    }else{
      msg_ = paste0("Group ",N_,"  = ", dat$Group[1])
      fplot <- ggplot2::ggplot()+ggplot2::geom_smooth(ggplot2::aes(
        x = dat[[X]] , y = dat[[Y]], color = as.factor(dat[["obs_u_01_a"]])) , method = method, se=F) + ggplot2::xlab(X) +
        ggplot2::ylab(Y) + ggplot2::ggtitle(msg_) + ggplot2::labs(color = C_IND) + ggplot2::theme_classic()

    }

    if (!(is.null(limits))){
      fplot = fplot + ggplot2::ylim(limits[1],limits[2])
    }


    return (fplot)
  }

}



#' @title Nested Plot
#'
#' @description This program creats nested plots for quick exploratory data analysis.
#'
#' @import ggplot2
#' @importFrom ggplot2 aes
#' @import purrr
#' @import dplyr
#' @importFrom dplyr %>%
#'
#' @param df Data Frame Object
#' @param v1 First variable (X-var of plot) that can be categorical or continuous.
#' @param v2 Second variable (Y-var of plot) that can be categorical or continuous.
#' @param v3 Third variable used to facet/group the X/Y variables, must be categorical.
#' @param obs.y Class variable of intrest, must be categorical. Can assigned NULL if NoCls = F.
#' @param iscat If X & Y are categorical, then this requires to be TRUE. If false scatter plots are used for nested plots.
#' @param freqz If iscat = TRUE, freqz displays frequency plots for nested categorys.
#' @param pc For "freqz" plots, adjusts values to display percentages.
#' @param jW Jitter width for numerical scatter plots.
#' @param jH Jitter height for numerical scatter plots.
#' @param NoCls Refrain from including classification variable.
#' @param limits For scatter plots input y limits.
#' @return GGplot Object
#'
#' @export nestedPlot
nestedPlot <- function(df,v1,v2,v3,obs.y,iscat=T, freqz = F, pc = F,
                       jW = 0.35,jH = 0.35, NoCls = F, limits = NULL, plot.Trend = F, method = "auto"){


  if (is.null(v3)){
    df$Null = "Null"
    v3 = "Null"
  }

  if (is.null(obs.y)){
    df$Null2 = "Null2"
    obs.y = "Null2"
  }


  lists1.2 <- list()
  C = 1
  for (i in unique(df[[v3]]))
  {
    if (!is.na(i)){
      temp_ = df[df[[v3]] == i,]
      temp_$Group = i
      lists1.2[[C]] <- temp_
      C = C + 1
    }
  }


  plots1.1b <- purrr::map(lists1.2,fs1.1b,v1, v2, v3,obs.y,iscat,freqz,pc,jW,jH, NoCls,limits, plot.Trend, method)
  return (plots1.1b)

}





