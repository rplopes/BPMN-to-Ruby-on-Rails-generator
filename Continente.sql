SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`City`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`City` (
  `idCity` INT NOT NULL AUTO_INCREMENT ,
  `nameCity` TEXT NOT NULL ,
  PRIMARY KEY (`idCity`) ,
  UNIQUE INDEX `idCity_UNIQUE` (`idCity` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Office`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`Office` (
  `idOffice` INT NOT NULL AUTO_INCREMENT ,
  `addressOffice` TEXT NOT NULL ,
  `City_idCity` INT NOT NULL ,
  PRIMARY KEY (`idOffice`) ,
  UNIQUE INDEX `idInfrastructure_UNIQUE` (`idOffice` ASC) ,
  INDEX `fk_Office_City` (`City_idCity` ASC) ,
  CONSTRAINT `fk_Office_City`
    FOREIGN KEY (`City_idCity` )
    REFERENCES `mydb`.`City` (`idCity` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Store`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`Store` (
  `idStore` INT NOT NULL AUTO_INCREMENT ,
  `addressStore` TEXT NOT NULL ,
  `City_idCity` INT NOT NULL ,
  PRIMARY KEY (`idStore`) ,
  UNIQUE INDEX `idStore_UNIQUE` (`idStore` ASC) ,
  INDEX `fk_Store_City1` (`City_idCity` ASC) ,
  CONSTRAINT `fk_Store_City1`
    FOREIGN KEY (`City_idCity` )
    REFERENCES `mydb`.`City` (`idCity` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Storage`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`Storage` (
  `idStorage` INT NOT NULL AUTO_INCREMENT ,
  `addressStorage` TEXT NOT NULL ,
  `City_idCity` INT NOT NULL ,
  UNIQUE INDEX `idStorage_UNIQUE` (`idStorage` ASC) ,
  PRIMARY KEY (`idStorage`) ,
  INDEX `fk_Storage_City1` (`City_idCity` ASC) ,
  CONSTRAINT `fk_Storage_City1`
    FOREIGN KEY (`City_idCity` )
    REFERENCES `mydb`.`City` (`idCity` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Supplier`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`Supplier` (
  `idSupplier` INT NOT NULL AUTO_INCREMENT ,
  `nameSupplier` TEXT NOT NULL ,
  `addressSupplier` TEXT NOT NULL ,
  `City_idCity` INT NOT NULL ,
  PRIMARY KEY (`idSupplier`) ,
  UNIQUE INDEX `idSupplier_UNIQUE` (`idSupplier` ASC) ,
  INDEX `fk_Supplier_City1` (`City_idCity` ASC) ,
  CONSTRAINT `fk_Supplier_City1`
    FOREIGN KEY (`City_idCity` )
    REFERENCES `mydb`.`City` (`idCity` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Product`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`Product` (
  `idProduct` INT NOT NULL AUTO_INCREMENT ,
  `nameProduct` TEXT NOT NULL ,
  `Supplier_idSupplier` INT NOT NULL ,
  PRIMARY KEY (`idProduct`) ,
  UNIQUE INDEX `idProduct_UNIQUE` (`idProduct` ASC) ,
  INDEX `fk_Product_Supplier1` (`Supplier_idSupplier` ASC) ,
  CONSTRAINT `fk_Product_Supplier1`
    FOREIGN KEY (`Supplier_idSupplier` )
    REFERENCES `mydb`.`Supplier` (`idSupplier` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
